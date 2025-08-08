import os
import subprocess
import glob
import csv
#os.chdir("/rstudio-files/ccbr-data/R3_Projects/CCBR1402_ab/EC-Bulk-RNA-seq_2025-03-21_pipeline")

def main():
    template_files = []
    failed_templates = []
    failed_details = []  # List to store (template_name, error_message) tuples
    
    with open('run_pipeline.sh', 'r') as f:
        for line in f:
            line = line.strip()
            if 'run_workbook_template' in line and 'template_' in line:
                # Extract the template name from quotes
                # Format: run_workbook_template "template_CleanRawCounts" "1" "26"
                parts = line.split('"')
                if len(parts) >= 2:
                    template_name = parts[1] + ".R"  # First quoted string
                    if 'template_' in template_name:
                        template_files.append(template_name)
                      
    # Process each template file
    for template_file in template_files:
        print(f"Processing: {template_file}")
        base_name = os.path.splitext(template_file)[0]
        base_name = base_name.replace("template_", "")
        
        try:
            result = subprocess.run(f"Rscript {template_file}", shell=True, check=True, 
                                  capture_output=True, text=True)
        except subprocess.CalledProcessError as e:
            failed_templates.append(base_name)
            # Capture both stdout and stderr for comprehensive error information
            error_message = f"Return code: {e.returncode}"
            if e.stderr:
                error_message += f" | stderr: {e.stderr.strip()}"
            if e.stdout:
                error_message += f" | stdout: {e.stdout.strip()}"
            failed_details.append((base_name, error_message))
        except Exception as e:
            failed_templates.append(base_name)
            error_message = f"Unexpected error: {str(e)}"
            failed_details.append((base_name, error_message))
            
    # Write the original log file
    log_content = "Failed templates: " + ", ".join(failed_templates)
    with open('failed_templates.log', 'w') as log_file:
        log_file.write(log_content)
    
    # Create CSV table with failed templates and error messages
    if failed_details:
        with open('failed_templates_table.csv', 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            # Write header
            writer.writerow(['Template_name', 'Error_message'])
            # Write failed template data
            for template_name, error_message in failed_details:
                writer.writerow([template_name, error_message])
        print(f"\nCreated table with {len(failed_details)} failed templates: failed_templates_table.csv")
    else:
        print("\nNo failed templates to report!")
    
if __name__ == "__main__":
    main()
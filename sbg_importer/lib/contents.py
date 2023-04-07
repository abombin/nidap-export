rscript_tool_id = "degenhardthf/rscript-auto/rscript-tool-path-data/5"

cwl_rscript_content = """
class: CommandLineTool
cwlVersion: v1.2
$namespaces:
  sbg: 'https://sevenbridges.com'
id: degenhardthf/rscript-auto/rscript-tool-path-data/5
baseCommand:
  - Rscript
inputs:
  - id: script_file
    type: string?
    inputBinding:
      shellQuote: false
      position: 1
  - id: input_data
    type: 'File[]?'
    inputBinding:
      shellQuote: true
      position: 2
    loadContents: true
outputs:
  - id: output
    type: File?
    outputBinding:
      glob:
        - '*.rds'
        - '*.pdf'
        - '*.png'
        - '*.jpg'
label: Rscript tool path data
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: '{docker_image}'
"""
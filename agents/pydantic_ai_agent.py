
from pydantic import BaseModel
from typing import List
from textwrap import dedent
from pydantic_ai import Agent

# Clean single tool: Convert PDF to text using PyPDF2
from pydantic_ai.tools import RunContext
import io
import PyPDF2

# Define the output structure for the agent
class Haircut(BaseModel):
    asset_class: str
    valid_from: str
    valid_to: str
    duration_unit: str
    value: str

# Optionally, you can define a dependency type if needed (e.g., for file data)
class FileData(BaseModel):
    filepath: str
    content: bytes
    mime_type: str

# Instructions for the agent
instructions = dedent('''
    - You are a file parser agent. Force the model to get more data from the PDF.
    - ALWAYS CALL pdf_to_text TOOL to extract text from the PDF AND PASS THE TEXT TO GEMINI.
    - This is API call so expected to call multiple times to get the maximum data. If keep calling the API doen't mean the previous data is wrong.
    - You are trained to parse PDF files and extract specific information.
    - The PDF files are related to CME and its products.
    - The PDF files are contains information about Haircut Schedule.
    - The PDF has multiple pages, section, sections, tables, columns, rows, data, data points, and other information.
    - Parse the PDF, Main focus on Haircut Schedule  percentage. Give me the output in JSON format.
    - asset_class should be in the format of "Asset Class + Description" (e.g., "U.S. Treasuries T-Bills").
    - If Haircut Schedule is not available in the PDF, then should ignore the specific asset class.
                      
    JSON Keys follows: asset_class (Asset Class + Description), valid_from, valid_to, duration_unit and value
    Example JSON:
    [
        {
            "asset_class": "U.S. Treasuries  T-Bills",
            "valid_from": "0",
            "valid_to": "1",
            "duration_unit": "Years",
            "value": "1%",
        },{
            "asset_class": "U.S. Treasuries TNOTES",
            "valid_from": "1",
            "valid_to": "2",
            "duration_unit": "Years",
            "value": "2%",
        },{
            "asset_class": "U.S. Treasuries",
            "valid_from": "2",
            "valid_to": "3",
            "duration_unit": "Years",
            "value": "4%",
        }
    ]
''')


# Create the first agent using Gemini
haircut_agent = Agent[
    FileData, List[Haircut]
](
    'google-gla:gemini-2.0-flash-exp',
    deps_type=FileData,
    output_type=List[Haircut],
    instructions=instructions,
)


@haircut_agent.tool
def pdf_to_text(ctx: RunContext[FileData]) -> str:
    """Extracts all text from the PDF file using PyPDF2."""
    pdf_bytes = ctx.deps.content
    pdf_stream = io.BytesIO(pdf_bytes)
    reader = PyPDF2.PdfReader(pdf_stream)
    text = "\n".join(page.extract_text() or "" for page in reader.pages)
    print(f"Extracted {len(reader.pages)} pages from the PDF.")
    return text


if __name__ == "__main__":
    file_path = "acceptable-collateral-futures-options-select-forwards.pdf"
    with open(file_path, "rb") as f:
        pdf_content = f.read()
    file_data = FileData(
        filepath=file_path,
        content=pdf_content,
        mime_type="application/pdf"
    )
    # Run the first agent
    result1 = haircut_agent.run_sync(
        "Parse the PDF and extract Haircut Schedule data as JSON. The PDF have complex tables. Read all the pages and Get the maximum data from the PDF. If required re-iterate the process.",
        deps=file_data
    )
    print("--- First Agent Output (Gemini) ---")
    import json
    # result1.output is a list of Haircut objects; convert to JSON using .model_dump()
    if isinstance(result1.output, list) and result1.output and hasattr(result1.output[0], 'model_dump'):
        print(json.dumps([item.model_dump() for item in result1.output], indent=2, ensure_ascii=False))
    else:
        print(result1.output)

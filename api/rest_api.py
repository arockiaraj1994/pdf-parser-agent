from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from agents.pydantic_ai_agent import haircut_agent, FileData
import uvicorn

app = FastAPI()

# Allow CORS for all origins (adjust as needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/upload/")
async def upload_pdf(file: UploadFile = File(...)):
    if file.content_type != "application/pdf":
        return JSONResponse(status_code=400, content={"error": "Only PDF files are allowed."})
    pdf_content = await file.read()
    file_data = FileData(
        filepath=file.filename,
        content=pdf_content,
        mime_type=file.content_type
    )
    # Run the agent asynchronously and await the coroutine
    result = await haircut_agent.run(
        "Parse the PDF and extract Haircut Schedule data as JSON. The PDF have complex tables. "
        "Run Minimum 4 iterations to get the maximum data from the PDF.",
        deps=file_data
    )
    # Convert output to JSON serializable format
    if isinstance(result.output, list) and result.output and hasattr(result.output[0], 'model_dump'):
        output = [item.model_dump() for item in result.output]
    else:
        output = result.output
    return {"result": output}

if __name__ == "__main__":
    uvicorn.run("file_processor.api:app", host="0.0.0.0", port=8000, reload=True)

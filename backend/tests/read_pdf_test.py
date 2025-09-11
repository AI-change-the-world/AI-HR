import sys

sys.path.append("..")

from utils.document_parser import parse_document

if __name__ == "__main__":
    file_path = (
        r"C:\Users\xiaoshuyui\github_repo\AI-HR\testdata\张三 - 资深前端工程师简历.pdf"
    )
    with open(file_path, "rb") as f:
        content = f.read()
    print(parse_document(content, ".pdf"))

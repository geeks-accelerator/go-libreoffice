
Enable libreoffice support in GO with the use of [github.com/dveselov/go-libreofficekit](https://github.com/dveselov/go-libreofficekit).

The example should support converting a PDF file to DOCX with support for images.

The code to be deployed to AWS Lambda and therefore needs to be built using the base AWS Amazon Linux. 
AWS provides the base image `lambci/lambda:build-go1.x` for building GO Lambda functions. 

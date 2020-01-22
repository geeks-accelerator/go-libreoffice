package main

import (
	"github.com/dveselov/go-libreofficekit"
)

func main() {
	office, _ := libreofficekit.NewOffice("/usr/lib/libreoffice")

	document, _ := office.LoadDocument("kittens.pdf")
	document.SaveAs("kittens.docx", "docx", "")

	document.Close()
	office.Close()
}


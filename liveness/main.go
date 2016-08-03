package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

func main() {
	fmt.Println("Checking if directory has files.")

	ignore := flag.String("ignore", ".git,lost+found", "files or directories to ignore")
	flag.Parse()
	fmt.Printf("Ignoring %s\n", *ignore)

	// Ensure we only have a single argument.
	if len(flag.Args()) != 1 {
		fmt.Fprintf(os.Stderr, "Usage: %s DIRECTORY -ignore=.git,lost+found\n", os.Args[0])
		os.Exit(1)
	}

	// Split the ignore flag by the comma and create a map for easy searching.
	ignoreSlice := strings.Split(*ignore, ",")
	ignores := make(map[string]bool)
	for _, i := range ignoreSlice {
		ignores[i] = true
	}

	// Get the files within the directory specified by the argument.
	files, err := ioutil.ReadDir(flag.Args()[0])
	if err != nil {
		log.Fatal(err)
	}

	fileCount := len(files)
	log.Printf("%d files in the directory.\n", fileCount)

	// Loop through files and decrease fileCount if file should be ignored.
	for i := 0; i < len(files); i++ {
		fileName := files[i].Name()
		if ignores[fileName] {
			log.Printf("Found %s, which is ignored.", fileName)
			fileCount--
		}
	}

	// If there are no remaining files, exit.
	if fileCount == 0 {
		log.Fatal("No files in the directory. Exiting.")
	}

	log.Printf("There are files in the directory. Success")
}

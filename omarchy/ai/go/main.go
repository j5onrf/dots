package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

func main() {
	blue := "\033[1;34m"; green := "\033[32m"; yellow := "\033[33m"
	white := "\033[1;37m"; dim := "\033[2m"; reset := "\033[0m"

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT)
	go func() {
    for {
        <-sigChan
        // Added \n at the end to move the cursor down
        fmt.Printf("\n%s[Interrupt trapped]%s\n", "\033[31m", reset)
    }
}()

	reader := bufio.NewReader(os.Stdin)

	for {
		// Updated Label
		fmt.Printf("\n%sQwen3.6:35b-a3b%s %s❯%s ", blue, reset, white, reset)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		if input == "exit" || input == "quit" { break }
		if input == "/clear" || input == "/c" {
    fmt.Print("\033[H\033[2J") // Standard ANSI clear screen
    continue
}

		// Model Tag
		cmd := exec.Command("ollama", "run", "qwen3.6:35b-a3b", "--think=false", "--verbose", input)
		stdout, _ := cmd.StdoutPipe()
		stderr, _ := cmd.StderrPipe()
		var errBuf bytes.Buffer
		
		start := time.Now()
		cmd.Start()
		go io.Copy(&errBuf, stderr)

		fmt.Print(green)
		inCode := false
		backticks := 0
		charCount := 0

		buf := make([]byte, 1)
		for {
			_, err := stdout.Read(buf)
			if err != nil { break }
			char := buf[0]
			charCount++
			
			if char == '`' {
				backticks++
			} else {
				if backticks == 3 {
					if !inCode { fmt.Print(yellow); inCode = true } else { fmt.Print(green); inCode = false }
				}
				backticks = 0
			}
			os.Stdout.Write(buf)
		}

		cmd.Wait()
		duration := time.Since(start)

		tps := (float64(charCount) / 4.0) / duration.Seconds()

		fmt.Print(reset)
		if charCount > 0 {
			fmt.Printf("\n%s───%s\n%sSpeed: %.2f tok/s | Time: %v%s\n", dim, reset, dim, tps, duration.Round(time.Millisecond), reset)
		}
	}
}

import Foundation

var pipes = [Pipe]()
while true {
  let pipe = Pipe()
  if pipe.fileHandleForReading.fileDescriptor == 0 && pipe.fileHandleForWriting.fileDescriptor == 0 {
    fatalError("Pipe() succeeded but produced invalid/unusable pipe.")
  }
  pipes.append(pipe)
}


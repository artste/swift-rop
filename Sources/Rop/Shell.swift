import Foundation

public struct ShellCommandError: DescriptiveError {
    let code: Int32 // Immutable
    let msg: String // Immutable
    init(_ code: Int32, _ msg: String) { 
        self.code = code
        self.msg = msg 
    }
    public func errorMessage() -> String { return "[\(code)]: \(msg)" }
}

@discardableResult
public func shell(_ launchPath: String, _ arguments: [String] = []) -> Result<String>
{
    let task = Process()
    task.executableURL = URL(fileURLWithPath: launchPath)
    task.arguments = arguments

    let pipe = Pipe(); task.standardOutput = pipe
    let errPipe = Pipe(); task.standardError = errPipe
    do {
        try task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let stdErr = errPipe.fileHandleForReading.readDataToEndOfFile()
        let text = String(data: data, encoding: String.Encoding.utf8) ?? ""
        let err = String(data: stdErr, encoding: String.Encoding.utf8) ?? ""
        if 0==task.terminationStatus {
            return good(text)
        } else {
            // Don't use the standard "bad" result, but keep termination status...
            return bad(ShellCommandError(task.terminationStatus, err))
        }
    } catch {
        return bad("ERROR: \(error).") // Incredible, to convert it I've just changed print to "bad"
    }
}
import Foundation
import CocoaLumberjack

public enum CVSLogger {
    public static let `default` = createLogger(category: "default")

    public static func createLogger(subsystem: String = Bundle.main.bundleIdentifier!,
                                    category: String,
                                    spamToXcode: Bool = false) -> CVSLog {
        let log = CVSLog()
        log.category = category
        if spamToXcode {
            log.add(DDOSLogger(subsystem: subsystem, category: category))
        }
        log.add(fileLogger)
        return log
    }

    private static let fileLogger: DDFileLogger = {
        let logFileManager = CSVFileManager()
        let fileLogger = DDFileLogger(logFileManager: logFileManager)
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter = CSVFormatter()
        return fileLogger
    }()

    public static func currentLogFileURL() -> URL? {
        if let path = fileLogger.currentLogFileInfo?.filePath {
            return URL(fileURLWithPath: path)
        } else {
            return nil
        }
    }
}

private class CSVFileManager: DDLogFileManagerDefault {
    override var logFileHeader: String? {
        "date,category,level,file,function,message"
    }
}

public class CVSLog: DDLog {
    internal var category: String = "default"
}

class CSVFormatter: NSObject, DDLogFormatter {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
        return formatter
    }()

    private let levels: [DDLogLevel: String] = [
        .error: "error",
        .warning: "warning",
        .info: "info",
        .debug: "debug",
        .verbose: "verbose"
    ]

    func format(message logMessage: DDLogMessage) -> String? {
        let date = dateFormatter.string(from: logMessage.timestamp)
        let data = logMessage.representedObject as? [String: Any] ?? [:]
        let category = data["category"] as? String ?? ""
        let level = levels[logMessage.level] ?? ""
        let file = (logMessage.file as NSString).lastPathComponent + ":\(logMessage.line)"
        let function = logMessage.function ?? ""
        let message = logMessage.message
        let object = "\(data["object"] ?? "")"
        let components: [String] = [date, category, level, file, function, message, object]
            .map {
                "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            }
        return components.joined(separator: ",")
    }
}

extension CVSLog {
    public func verbose(_ message: String,
                        context: Int = 0,
                        file: StaticString = #file,
                        function: StaticString = #function,
                        line: UInt = #line,
                        timestamp: Date? = nil) {
        addLogItem(message, context: context, level: .verbose, flag: .verbose, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    public func info(_ message: String,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      timestamp: Date? = nil) {
        addLogItem(message, context: context, level: .info, flag: .info, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    public func debug(_ message: String,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      timestamp: Date? = nil) {
        addLogItem(message, context: context, level: .debug, flag: .debug, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    public func warning(_ message: String,
                         context: Int = 0,
                         file: StaticString = #file,
                         function: StaticString = #function,
                         line: UInt = #line,
                         timestamp: Date? = nil) {
        addLogItem(message, context: context, level: .warning, flag: .warning, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    public func error(_ message: String,
                       context: Int = 0,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line,
                       timestamp: Date? = nil) {
        addLogItem(message, context: context, level: .error, flag: .error, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    public func error(_ error: Error,
                       context: Int = 0,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line,
                       timestamp: Date? = nil) {
        addLogItem("\(error)", context: context, level: .error, flag: .error, file: file,
                   function: function, line: line, timestamp: timestamp)
    }

    private func addLogItem(_ message: String,
                            context: Int = 0,
                            level: DDLogLevel,
                            flag: DDLogFlag,
                            file: StaticString = #file,
                            function: StaticString = #function,
                            line: UInt = #line,
                            timestamp: Date? = nil) {
        let data: [String: Any] = ["category": category]
        log(
            asynchronous: true,
            message: DDLogMessage(
                format: message,
                formatted: message,
                level: level,
                flag: flag,
                context: context,
                file: "\(file)",
                function: "\(function)",
                line: line,
                tag: data,
                timestamp: timestamp
            )
        )
    }
}

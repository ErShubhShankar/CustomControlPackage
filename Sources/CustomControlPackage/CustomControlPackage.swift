struct CustomControlPackage {
    var text = "Hello, World!"
}

public class Logger {
    public init() {

    }
    public func log(message: String) {
        print("printing from package")
    }
}

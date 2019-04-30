public protocol DescriptiveError {
    func errorMessage()->String
}

public struct SimpleError: DescriptiveError {
    let msg: String // Immutable
    init(_ msg: String) { self.msg = msg }
    public func errorMessage() -> String { return msg }
}

public enum Result<OK> {
    case Ok(OK)
    case Error(DescriptiveError) // We always want an error that follows this protocol
    
    // Methods and Properties
    public var value: OK? {
        get {
            switch self {
                case .Ok(let value): return value
                case .Error(_): return nil // Don't need the value
            }
        }
    }    
    public var error: String? {
        get {
            switch self {
                case .Ok(_): return nil
                case .Error(let err): return err.errorMessage()
            }
        }
    }
    //MAP: spark of magic..
    public func then<OUT>(_ f: (OK)->OUT ) -> Result<OUT> {
        switch self {
            case .Ok(let val): return Result<OUT>.Ok(f(val))
            case .Error(let err): return Result<OUT>.Error(err) // Forward error
        }
    }
    //FLAT MAT: the real magic of monad! 
    public func then<OUT>(_ f: (OK)->Result<OUT> ) -> Result<OUT> {
        switch self {
            case .Ok(let val): return f(val)
            case .Error(let err): return Result<OUT>.Error(err) // Forward error
        }
    }
    //TAP: result snooping 
    public func use(_ f: (OK)->() ) -> Result<OK> {
        switch self {
            case .Ok(let val): f(val)
            case .Error(let err): print("ERROR HAS HAPPENED: \(err.errorMessage())")
        }
        return self
    }
    //Convenience
    public func isOk() -> Bool {
        switch self {
            case .Ok: return true
            case .Error: return false
        }
    }
}

//Convenience factory functions as static to quick find them with auto completition...
public func good<T>(_ value: T) -> Result<T> {
    return .Ok(value) // Thnx Chris ;-)
}
public func bad<T>(_ msg: String) -> Result<T> {
    return .Error(SimpleError(msg)) // Thnx Chris ;-)
}
//Create bad result from generic DescriptiveError
public func bad<T>(_ err: DescriptiveError) -> Result<T> {
    return Result<T>.Error(err)
}
//Forwards errors adapting type to destination...
public func bad<T,P>(_ parent: Result<P>) -> Result<T> {
    switch parent {
        case .Ok: return bad("WARNING: parent was not bad!") // good goes bad!! Warning!!
        case .Error(let val): return Result<T>.Error(val) // bad remains bad...
    }
}
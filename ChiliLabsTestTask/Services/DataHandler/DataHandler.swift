import Foundation

protocol DataHandler {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    func decodeData<T: Decodable>(data: Data) throws -> T
    func encodeData<T: Encodable>(data: T) throws -> Data
}

extension DataHandler {
    func decodeData<T: Decodable>(data: Data) throws -> T {
        do {
            if data.isEmpty {
                throw DataHandlerError.emptyData
            }
            
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            DebugLogger.printLog(error)
            throw DataHandlerError.invalidData
        }
    }
    
    func encodeData<T: Encodable>(data: T) throws -> Data {
        do {
            let encodedData = try encoder.encode(data)
            if encodedData.isEmpty {
                throw DataHandlerError.emptyData
            }
            return encodedData
        } catch {
            throw DataHandlerError.invalidData
        }
    }
}

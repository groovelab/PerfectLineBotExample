//
//  Extension.swift
//  PerfectLineBotExample
//
//  Created by Takeo Namba on 2016/05/07.
//  Copyright GrooveLab
//

import PerfectLib
import OpenSSL

extension String {
    func hmacSHA256(key key: String) -> String {
        let bytes = self.dynamicType.hmacSHA256(UTF8Encoding.decode(key), message: UTF8Encoding.decode(self))
        return self.dynamicType.base64encode(bytes)
    }
    
    static func base64encode(bytes: [UInt8]) -> String {
        let bio = BIO_push(BIO_new(BIO_f_base64()), BIO_new(BIO_s_mem()))
        
        BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL)
        BIO_write(bio, bytes, Int32(bytes.count))
        BIO_ctrl(bio, BIO_CTRL_FLUSH, 0, nil)
        
        var mem = UnsafeMutablePointer<BUF_MEM>(nil)
        BIO_ctrl(bio, BIO_C_GET_BUF_MEM_PTR, 0, &mem)
        BIO_ctrl(bio, BIO_CTRL_SET_CLOSE, Int(BIO_NOCLOSE), nil)
        BIO_free_all(bio)
        
        let txt = UnsafeMutablePointer<UInt8>(mem.memory.data)
        let ret = UTF8Encoding.encode(GenerateFromPointer(from: txt, count: mem.memory.length))
        free(mem.memory.data)
        return ret
    }
    
    static func hmacSHA256(key: [UInt8], message: [UInt8]) -> [UInt8] {
        var bytesLen: UInt32 = 0
        let bytes = UnsafeMutablePointer<UInt8>.alloc(Int(EVP_MAX_MD_SIZE))
        defer { bytes.destroy() ; bytes.dealloc(Int(EVP_MAX_MD_SIZE)) }
        
        key.withUnsafeBufferPointer { keyPtr in
            message.withUnsafeBufferPointer { msgPtr in
                HMAC(EVP_sha256(), keyPtr.baseAddress, Int32(key.count), msgPtr.baseAddress, msgPtr.count, bytes, &bytesLen)
            }
        }
        
        var r = [UInt8]()
        for idx in 0..<Int(bytesLen) {
            r.append(bytes[idx])
        }
        return r
    }
}


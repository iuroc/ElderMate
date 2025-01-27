import { fileIo } from '@kit.CoreFileKit'

export function readFile(path: string): ArrayBuffer {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
    const data = new ArrayBuffer(fileIo.statSync(path).size)
    fileIo.readSync(file.fd, data)
    fileIo.close(file)
    return data
}
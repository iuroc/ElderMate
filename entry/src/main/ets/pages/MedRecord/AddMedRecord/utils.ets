import { http } from "@kit.NetworkKit"
import { apiOrigin } from "../../../common/config"
import { getLoginInfo } from "../../Login/utils"
import { url } from "@kit.ArkTS"
import { ApiResponse } from "../../../common/types"

export interface AddMedRecordPopResult {
    result: CreateMedRecordResult
    config: CreateMedRecordConfig
    imageURLs: string[]
}

export interface MedRecordListResultItem {
    id: number
    visitDate: string
    hospitalName: string
    createTime: string
    images: Record<'url', string>[]
}

export interface CreateMedRecordConfig {
    visitDate: Date
    hospitalName: string
    medRecord: string
    imageURLs: string[]
    editId?: number
}

interface CreateMedRecordResult {
    id: number
    createTime: string
}

export async function createMedRecord(config: CreateMedRecordConfig) {
    const request = http.createHttp()
    const params = new url.URLParams({
        visitDate: config.visitDate.getTime().toString(),
        hospitalName: config.hospitalName.trim(),
    })
    if (config.medRecord.trim()) {
        params.set('medRecord', config.medRecord.trim())
    }
    if (config.imageURLs.length > 0) {
        params.set('visitImages', config.imageURLs.join('|'))
    }
    if (config.editId != null) {
        params.set('id', config.editId.toString())
    }
    const response = await request.request(apiOrigin + '/api/medRecord/create', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        header: {
            token: await getLoginInfo(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: params.toString()
    })
    const result = response.result as ApiResponse<CreateMedRecordResult>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}


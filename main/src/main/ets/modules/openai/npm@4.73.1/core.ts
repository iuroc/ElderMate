import { type RequestInfo, type RequestInit, type Response, } from './_shims/index';

export { type Response };

export type Fetch = (url: RequestInfo, init?: RequestInit) => Promise<Response>;

export type RequestClient = { fetch: Fetch };

export type Headers = Record<string, string | null | undefined>;

export type DefaultQuery = Record<string, string | undefined>;

export type KeysEnum<T> = { [P in keyof Required<T>]: true };

export interface HeadersProtocol {
    get: (header: string) => string | null | undefined;
}

export type HeadersLike = Record<string, string | string[] | undefined> | HeadersProtocol;

export const isHeadersProtocol = (headers: any): headers is HeadersProtocol => {
    return typeof headers?.get === 'function';
};

export const getRequiredHeader = (headers: HeadersLike | Headers, header: string): string => {
    const foundHeader = getHeader(headers, header);
    if (foundHeader === undefined) {
        throw new Error(`Could not find ${header} header`);
    }
    return foundHeader;
};

export const getHeader = (headers: HeadersLike | Headers, header: string): string | undefined => {
    const lowerCasedHeader = header.toLowerCase();
    if (isHeadersProtocol(headers)) {
        // to deal with the case where the header looks like Stainless-Event-Id
        const intercapsHeader =
            header[0]?.toUpperCase() +
            header.substring(1).replace(/([^\w])(\w)/g, (_m, g1, g2) => g1 + g2.toUpperCase());
        for (const key of [header, lowerCasedHeader, header.toUpperCase(), intercapsHeader]) {
            const value = headers.get(key);
            if (value) {
                return value;
            }
        }
    }

    for (const [key, value] of Object.entries(headers)) {
        if (key.toLowerCase() === lowerCasedHeader) {
            if (Array.isArray(value)) {
                if (value.length <= 1) {
                    return value[0];
                }
                console.warn(`Received ${value.length} entries for the ${header} header, using the first entry.`);
                return value[0];
            }
            return value;
        }
    }
    return undefined;
};

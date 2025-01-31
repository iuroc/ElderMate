/**
 * 查看日期是否比今天更早
 * @param date
 * @returns
 */
export function isBeforeToday(date: Date): boolean {
    return isABeforeB(date, new Date())
}

/**
 * 判断日期 A 是否比日期 B 早，这里只比较日期，不包含世间
 *
 * 比如 2025-01-01 比 2025-01-02 早
 * @param a
 * @param b
 */
export function isABeforeB(a: Date, b: Date): boolean {
    a.setHours(0, 0, 0, 0)
    b.setHours(0, 0, 0, 0)
    return a.getTime() < b.getTime()
}

/**
 * 计算两个 Date 之间包含多少天（包含起止日期）
 * @param startDate
 * @param endDate
 * @returns
 */
export function daysBetweenInclusive(startDate: Date, endDate: Date): number {
    const start = new Date(startDate)
    start.setHours(0, 0, 0, 0)
    const end = new Date(endDate)
    end.setHours(0, 0, 0, 0)
    const diffTime = end.getTime() - start.getTime()
    const diffDays = Math.abs(diffTime) / (1000 * 60 * 60 * 24)
    return diffDays + 1
}
import { data } from './data.js'

export const fetchData = () => {
    return new Promise((resolve, reject) => {
        console.log("Hallo")
        resolve(data)
    })
}
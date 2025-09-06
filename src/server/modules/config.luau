export type team = {
    name : string,
    max : number,
    min : number,
    show : boolean | nil
}

return {
    teams = {
        {
            name = 'Director',
            max = 1,
            min = 1
        },
        {
            name = 'Administrator',
            max = -1,
            min = -1
        },
        {
            name = 'Info-Managers',
            max = 3,
            min = -1
        },
        {
            name = 'Data Analysts',
            max = 2,
            min = 1
        },
        {
            name = 'Guards',
            max = -1,
            min = 2
        },
        {
            name = 'Engineers',
            max = 5,
            min = 2,
        },
        {
            name = 'Scientists',
            max = 5,
            min = 2,
        }
    } :: {team}
}
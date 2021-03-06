--
-- gh-5224: tuple field access by JSON path crashed when tried to get a multikey
-- indexed field.
--
format = {}
format[1] = {name = 'f1', type = 'unsigned'}
format[2] = {name = 'f2', type = 'array'}
s = box.schema.create_space('test', {format = format})
_ = s:create_index('pk')
_ = s:create_index('sk', {                                                      \
    parts = {                                                                   \
        {field = 2, path = "[*].tags", type = "unsigned"}                       \
    }                                                                           \
})

t = s:replace{1, {{tags = 2}}}
t['[2][1].tags']

t = s:replace{1, {{tags = 2}, {tags = 3}, {tags = 4}}}
t['[2]']
t['[2][1]']
t['[2][1].tags']
t['[2][2]']
t['[2][2].tags']
t['[2][3]']
t['[2][3].tags']

s:truncate()
s.index.sk:drop()
_ = s:create_index('sk', {                                                      \
    parts = {                                                                   \
        {field = 2, path = "[*].p1.p2", type = "unsigned"}                      \
    }                                                                           \
})

t = s:replace{1, {{p1 = {p2 = 2}}}}
t['[2][1].p1.p2']

t = s:replace{1, {                                                              \
    {                                                                           \
        p1 = {                                                                  \
            p2 = 2, p3 = 3                                                      \
        },                                                                      \
        p4 = 4                                                                  \
    },                                                                          \
    {                                                                           \
        p1 = {p2 = 5}                                                           \
    },                                                                          \
    {                                                                           \
        p1 = {p2 = 6}                                                           \
    }                                                                           \
}}

t['[2][1].p1.p2']
t['[2][1].p1.p3']
t['[2][1].p1']
t['[2][1]']
t['[2][1].p4']
t['[2][2].p1.p2']
t['[2][2].p1']
t['[2][2]']
t['[2][3].p1.p2']
t['[2][3].p1']
t['[2][3]']

--
-- Multikey path part could crash when used as a first part of the path during
-- accessing a tuple field.
--
t['[*]']

s:drop()

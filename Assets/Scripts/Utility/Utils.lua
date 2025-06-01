--!Type(Module)
function PrintTable(t, indent)
    indent = indent or ''
    for k, v in pairs(t) do
      if type(v) == 'table' then
        print(indent .. k .. ' :')
        PrintTable(v, indent .. '  ')
      else
        print(indent .. k .. ' : ' .. tostring(v))
      end
    end
  end
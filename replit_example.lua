
-----------------------------------------------------------
-- This stuff at the top is just to make the terminal -----
-- Act more like mudlet, The important code is at to bottom
----- Class Definition on line 142 ------------------------
-------------- Example on line 475 ------------------------
-----------------------------------------------------------

--------------------------------------------------------------------------
------- Mudlet Emulation -------------------------------------------------
--------------------------------------------------------------------------


--- make copies of some mudlet functions to test scripts outside of mudlet
function cecho (msg)
    io.write(msg)
end

function echo (msg)
    io.write(msg)
end

function send (cmd)
    print("(SENT): "..cmd)
end
--unset table.save and load to prevent accidents
function table.save()
end
function table.load()
end




-- unset, can implement later
function registerAnonymousEventHandler(event,func)
end


function raiseEvent(event)
    print("(EVENT): "..event)
end


do local indents = {}  -- simulate a static variable
        function indent(num)

          if not indents[num] then
            indents[num] = ""
            for i = 0, num do
              indents[num] = indents[num].."  "
            end
          end

          return indents[num]
        end
end
-- Basically like tostring(), except takes a numformat
-- and is a little better suited for working with display()
-- Handles indentation


-- Extending default libraries makes Babelfish happy.
setmetatable( _G, {
        ["__call"] = function(func, ...)
                if type(func) == "function" then
                        return func(...)
                else
                        local h = metatable(func).__call
                        if h then
                                return h(func, ...)
                        elseif _G[type(func)][func] then
                                _G[type(func)][func](...)
                        else
                                debug("Error attempting to call function " .. func .. ", function does not exist.")
                        end
                end
        end,
        })

function printable(what, numformat)
  local ret

  if type(what) == 'string' then
    ret = "'"..what.."'"
--    ret = string.format("%q", what)    -- this was ugly

  elseif type(what) == 'number' then
    if numformat then ret = string.format(numformat, what)
    else ret = what end

  elseif type(what) == 'boolean' then
    ret = tostring(what)

  elseif type(what) == 'table' then
    ret = what.__customtype or type(what)

  else
    ret = type(what)
--    ret = tostring(what)               -- this was ugly
  end

  return ret
end

-- pretty display function
function display(what, numformat, recursion)
  recursion = recursion or 0

  if recursion == 0 then
    io.write("\n")
--    echo("-------------------------------------------------------\n")
  end
  io.write(printable(what, numformat))

  -- Do all the stuff inside a table
  if type(what) == 'table' then
    io.write(" {")

    local firstline = true   -- a kludge so empty tables print on one line
    for k, v in pairs(what) do
      if firstline then io.write("\n"); firstline = false end
      io.write(indent(recursion))
      io.write(printable(k))
      io.write(" = ")
      if not (v == _G) then display(v, numformat, recursion + 1) end
    end

    -- so empty tables print as {} instead of {..indent..}
    if not firstline then io.write(indent(recursion - 1)) end
    io.write("}")
  end

  io.write("\n")
  if recursion == 0 then
--    echo ("-------------------------------------------------------\n")
  end
end



------------------------------------------------------------------------------
------- DB CLASS DEFINITION --------------------------------------------------
------------------------------------------------------------------------------
-- version: 0.1
-- Author: Fusco
-- Desc: a class meant to imitate the functionality of a
--       2 dimensional sortable table or database
--TODO: Add more events?, add functionality for tables as elements,
------- empty field coercion, create a greedy search
------- type checking and coercion on entire field
------- Figure out how to save primary key and name directly to file
------- sort numbers as strings while preserving type
------- getCopy

db = {}

function db.new(name,primary)
  if name == nil or primary == nil then
    error("db.new requires both arguments")
    return
  end
  ---------------- class variables ------------------------------
	local self = {}
	local primary = primary   -- primary key
	local name = name      -- name of the db
	local members = {}   -- this table will hold everything we care about

	
  ------------ PRIVATE methods ------------------------------------

	local function db_err(msg) -- prints error messages
		cecho("<white> [<red>"..name.." Error<white>]<grey>: "..msg.."\n")
    error(name..": "..msg)
	end --end
	  
  -------------- Public Methods ---------------------------------

	---- save/load ----
	-- defaults to home directory and name of the db
  -- paramaters currently unused
	registerAnonymousEventHandler(name.." members update","save")
	function self.save (path)
    if path == nil then path = name.."_members.lua" end
		table.save(getMudletHomeDir().."\\"..name.."_members.lua", members)
  end --savedb
	
	function self.load (path)
    if path == nil then path = name.."_members.lua" end
		table.load(getMudletHomeDir().."\\"..name.."_members.lua", members)
	end --loaddb


    -- directly set members = to some table
    -- !!this is dangerous, put in error checking
  function self.copy (tab)
    members = tab
    raiseEvent(name.." members update")
  end
    
	-- take an existing parallel dictionary and copy it into members
	-- as a parallel array, returns true on success
	-- defaults to calling primary key "id" if another name isn't specified
	function self.pdCopy (pd)
		if type(primary) ~= "string" then
		    db_err("Keyname must be type string instead of "..type(keyname))
		    return false
		end --if

		-- only allow on fresh db
		if members[1] ~= nil then
			db_err("Cannot copy to a non-empty db.")
			return false
		end --if
		-- check that input is valid
		for k,v in pairs(pd) do
			if type(v) ~= "table" then
				db_err("Input is not a parallel dictionary.")
				return false
			end
		end --for
		
		for k,v in pairs(pd) do
			table.insert(members,1,v)
		    members[1][primary] = k			
		end --for
		raiseEvent(name.." members update")
		return true
	end --pdCopy

  function self.getPrimary () --returns primary key
    return primary
  end -- getPrimary
  
  function self.getName () --returns name
    return name
  end -- getName

	-- insert an entry into members, defaults to end of table
	-- returns false on errors
	function self.insert(entry,pos)
       
		-- only accept tables as entries
		if type(entry) ~= "table" then
			db_err("Can only insert tables into db, not "..type(entry).."s.")
			return false
		end -- if
		
		-- reqire primary field
        if entry[primary] == nil then
            db_err("db object requires the key "..strictKey..".")
            return false
        end --if
        
        for i,v in ipairs(members) do
            if v[primary]==entry[primary] then
                db_err("Cannot insert multiple entries with primary key = "..primary)
                return false
            end -- if
        end -- for

		-- insert entry into members
		if pos == nil then table.insert(members,entry) else
			table.insert(members,pos,entry)	
		end --if
    raiseEvent(name.." members update")
		return true
	end -- insert
	
	-- inserts all entries in a table into the db
	-- limited error checking, use carefully
	function self.insertAll(t)
		for k,v in pairs(t) do
			if type(v) == "table" then
				self.insert(v)
			else
				db_err("insertAll requires a table of tables as a paramater.")
				return false
			end --if
		end --for
    raiseEvent(name.." members update")
	end -- insertAll
	
	-- delete and return an entry from members by position
	-- defaults to end of table
	function self.remove(pos)
		if type(pos) ~= "number" then 
			db_err("Remove method requires argument number or nil, not "..type(pos))
			return false
		end -- if
		if pos == nil then pos = getn(members) end
    raiseEvent(name.." members update")
		return table.remove(members,pos)  
	end
	
	-- delete any entries with key, value pair specified
	-- will return the deleted entry if db is strictKey
	function self.removePairs(key,value)
		for i=table.getn(members),1,-1 do
      local v = members[i]
			if v[key] == value then
				table.remove(members,i)
			end --if
		end --for
    raiseEvent(name.." members update")
    return
  end --removePairs
  
  -- delete a member by its primary key
  function self.removeKey(pkey)
		for i=table.getn(members),1,-1 do
      local v = members[i]
			if v[primary] == pkey then
				table.remove(members,i)
			end --if
		end --for
  raiseEvent(name.." members update")
	return
	end --removeKey
	
  --Check if there an entry is in the table
  --returns true or false
  function self.exists(pkey)
    for i,v in ipairs(members) do
      if v[primary] == pkey then return true end
    end -- for
    return false  --key wasn't found
	end --exists()
  --TODO: error checking for set and get
	function self.get (pkey,field)
	    for i,v in ipairs(members) do
	        if v[primary] == pkey then
              return v[field]
	        end --if  
	    end
      return nil
	end -- get
  -- return a single row of the table
  function self.getEntry (pkey)
	  for i,v in ipairs(members) do
	    if v[primary] == pkey then
        return members[i]
	    end --if  
	  end
    return nil
	end -- get
	
	function self.set (pkey,field,newval)
	    for i,v in ipairs(member) do
	        -- does key exist?
	        if v[primary] == pkey then
	            v[field] = newval
	        end
          db_err("Key ("..pkey..") does not exist")
	    end
	end -- set
  -- add parameter to numeric value, field must be numeric
  function self.add (pkey,field,addend)
    -- require numeric field
    if type(field) ~= "number" then
      db_err("Cannot use add method on a "..type(field).." field.")
      return false
    end
    
    for i,v in ipairs(member) do
	        -- does key exist?
	        if v[primary] == pkey then
	            v[field] = v[field] + addend
	        end
          db_err("Key ("..pkey..") does not exist")
	   end --for
  end -- add()
  
	-- displays element with primary key
	-- if none specified, displays entire table
	function self.display(pkey)
		if pkey then
            local notFound = true
            for i,v in ipairs(members) do
                if v[primary] == pkey then
                    display(members[i])
                    notFound = false
                end --if
            end -- for
            if notFound then display(nil) end
        else
            display(members)
        end --if
	end --display
        
	
	-- probably could be better
	-- check if 'key = value' pair exists, returns its position or false
  function self.isPair(key,value)
		for i,v in ipairs(members) do
			if v[key] == value then
				return i
			end
    end
	  return false
	end


	-- return a copy of members with only entries where 'key = value'
	function self.search(key,value)
		-- error checking
		if key == nil then
			db_err("getAll(key,value) requires a non-nil key.")
			return 
		end --if
		output = {}
		for i,v in ipairs(members) do
			if v[key] == value then
				table.insert(output,v)
			end	--if
		end -- for
		
		return output
			
	end --getAll
	
	--sort by 'field', sorts in ascending order unless second
	--argument is true
	--will not work on numbers stored as string, must coerce
	--returns true if runs successfully
  function self.sort(field,descending)
		--error checking
		if field == nil then 
			db_err("Requires a field to sort over.")
			return false 
		end --if
		--ensure field exists and is valid type
		local ftype = type(members[1][field])
		for i,v in pairs(members) do
			if type(v[field]) ~= "string" and type(v[field]) ~= "number"  then
				db_err("Invalid field. Cannot process type "..type(v[field])..".")
				return
			end --if
			if type(v[field]) ~= ftype then
				db_err("All entries in a field must be same type.")
				return
			end --if
		end -- for
		
		local n = 1
		local size = table.getn(members)
		
		
		while n <= size do
			local maxi = n
			for i= n, (size-1) do
				if members[i+1][field]  >  members[maxi][field] then
					maxi = i+1
				end --if
    	    end -- for
    	    -- pull out biggest entry
            local tentry = table.remove(members,maxi)
			if descending then
    			table.insert(members,n,tentry)
            else
                table.insert(members,1,tentry)
            end

     		n = n + 1
		end--while
		return members
	end --sort

 	return self            
end --db class type




----------------------------------------------------------------------------
------- DB CLASS EXAMPLE CODE ----------------------------------------------
----------------------------------------------------------------------------

----- an example db to test methods -------

-- this is the data that will be loaded into the new object
-- I'm using the copy method, which is a quick and dirty
-- function and bad practice, use the copy method with care
exampleMembers = {
     {id=1, name = "one",  data = 0           },
     {id=2, name = "two",  data = -3.1415     },
     {id=3, name = "three",data = 42          },
     {id=4, name = "four", data = 2.99792458e8},
     {id=5, name = "five", data = 2.718       },
     {id=6, name = "seven",  data = -2.718    },
     {id=7, name = "seven",data = 1           },
     {id=8, name = "eight",data = 1           },
     {id=9, name = "nine", data = 2           },
     {id=10,name = "ten",  data = 299792458   },
}    
    
-- db.new returns our new object, whic is assigned to 'example'   
example = db.new("example","id")
-- copy exampleMembers table to the members table in the object
-- !!! copy is a sketchy function
example.copy(exampleMembers)

--display() prints entire table, display(pkey) prints an entry
print("\n\n\nEx: example.display(4)")
example.display(4)

print("")

-- search returns a table of all elements that match a key,value pair
print([[Ex: display(example.search("name","seven"))]])
display(example.search("name","seven"))

print("")

-- exists(pkey) returns a true/false depending on if that key exists
if example.exists(1) then print("id=1 exists!") else print("Nope.") end
if example.exists(0) then print("id=0 exists!") else print("Zero zeroes.") end

-- sorting, method returns the sorted table
sorted = example.sort("data")
--display(sorted)
print("\n--- Sorted by data, ascending ---")
print("        id : name :data")
print("---------------------------------")
for i,v in pairs(sorted) do 
  io.write("         "..v["id"].." : ")
  io.write(v["name"].." : ")
  io.write(v["data"].."\n\n")
end

-- add a row to the table
newRow = {id=11,name="doubleone",data=103845}
example.insert(newRow)

sorted = example.sort("name",true)
print("\n--- Sorted by name, descending ---")
print("        id : name :data")
print("----------------------------------")
for i,v in pairs(sorted) do 
  io.write("         "..v["id"].." : ")
  io.write(v["name"].." : ")
  io.write(v["data"].."\n")
end










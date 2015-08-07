-- require "db_class"
-- uncomment the require line if you're running this in
-- an ide so the interpreter knows to load the class

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

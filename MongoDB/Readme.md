Alright Balu, here is a no-nonsense MongoDB cheat sheet. Old school DB instincts, new school syntax.

**Basics**

* `show dbs`
* `use mydb`
* `show collections`

**CRUD**

* Insert: `db.users.insertOne({name:"A", age:30})`
* Find: `db.users.find({age:{$gt:25}})`
* Update: `db.users.updateOne({name:"A"}, {$set:{age:31}})`
* Delete: `db.users.deleteOne({name:"A"})`

**Query operators**

* `$gt $lt $gte $lte`
* `$in $nin`
* `$and $or`
* `$exists`

**Projection**

* `db.users.find({}, {name:1, _id:0})`

**Sorting & limiting**

* `.sort({age:-1}).limit(5).skip(5)`

**Aggregation**

* `$match`
* `$group`
* `$sum $avg $count`
* `$sort`
* `$project`

**Index**

* `db.users.createIndex({email:1})`

SQL brain tip: collections = tables, documents = rows, but schema stays chill.

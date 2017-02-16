import StORM
import PostgresStORM

class Acronym: PostgresStORM {

  var id: Int = 0
  var short: String = ""
  var long: String = ""

	override open func table() -> String { return "acronyms" }

	override func to(_ this: StORMRow) {
		id = this.data["id"] as? Int ?? 0
		short	= this.data["short"] as? String	?? ""
		long = this.data["long"] as? String	?? ""
	}

	func rows() -> [Acronym] {
		var rows = [Acronym]()
		for i in 0..<self.results.rows.count {
			let row = Acronym()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

  func asDictionary() -> [String: Any] {
    return [
      "id": self.id,
      "short": self.short,
      "long": self.long
    ]
  }

  static func all() throws -> [Acronym] {
    let getObj = Acronym()
    try getObj.findAll()
    return getObj.rows()
  }

  static func first() throws -> Acronym? {
    let getObj = Acronym()
    let cursor = StORMCursor(limit: 1, offset: 0)
    try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
    return getObj.rows().first
  }

  static func getAcronym(matchingId id:Int) throws -> Acronym {
    let getObj = Acronym()
    var findObj = [String: Any]()
    findObj["id"] = "\(id)"
    try getObj.find(findObj)
    return getObj
  }

  static func getAcronyms(matchingShort short:String) throws -> [Acronym] {
    let getObj = Acronym()
    var findObj = [String: Any]()
    findObj["short"] = short
    try getObj.find(findObj)
    return getObj.rows()
  }

  static func getAcronyms(notMatchingShort short:String) throws -> [Acronym] {
    let getObj = Acronym()
    try getObj.select(whereclause: "short != $1", params: ["AFK"], orderby: ["id"])
    return getObj.rows()
  }

}

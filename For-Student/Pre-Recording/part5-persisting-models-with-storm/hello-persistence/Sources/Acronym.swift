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

}

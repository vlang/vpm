module main

import vweb

 fn (app &App) search (q string) vweb.Result {
 	// TODO uncomment once ORM supports LIKE
// 	packages := sql app.db {
	// 	select from Package where name

	// }

 return $vweb.html()

}

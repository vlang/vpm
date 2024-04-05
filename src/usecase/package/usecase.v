module package

pub struct UseCase {
pub:
	categories CategoriesRepo @[required]
	packages   PackagesRepo   @[required]
	users      UsersRepo      @[required]
}

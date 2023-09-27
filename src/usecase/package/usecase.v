module package

pub struct UseCase {
	categories CategoriesRepo [required]
	packages   PackagesRepo   [required]
}

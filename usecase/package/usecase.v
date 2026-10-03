module package

pub struct UseCase {
pub:
	packages      PackagesRepo      @[required]
	users         UsersRepo         @[required]
	organizations OrganizationsRepo @[required]
}

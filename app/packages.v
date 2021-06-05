module app

import nedpals.vex.ctx
import vpm.models
import vpm.service

pub struct Package {
pub:
	models.Package
	tags []models.Tag
	categories []models.Category
	versions []models.Version
}

fn get_package(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	package := app.services.packages.get_by_name(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	tags := app.services.tags.get_by_package(package.id) or {
		match err {
			service.NotFoundError {
				[]models.Tag{}
			}
			else {
				wrap_service_error(req, mut res, err)	
			}
		}

		return
	}

	categories := app.services.categories.get_by_package(package.id) or {
		match err {
			service.NotFoundError {
				[]models.Category{}
			}
			else {
				wrap_service_error(req, mut res, err)	
			}
		}

		return
	}

	versions := app.services.versions.get_by_package(package.id) or {
		match err {
			service.NotFoundError {
				[]models.Version{}
			}
			else {
				wrap_service_error(req, mut res, err)	
			}
		}

		return
	}

	result := Package{
		Package: package
		tags: tags
		categories: categories
		versions: versions
	}

	res.send_json(result, 200)
}

fn get_package_version(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	package := app.services.packages.get_by_name(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	version := app.services.versions.get(package.id, req.params['version']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(version, 200)
}

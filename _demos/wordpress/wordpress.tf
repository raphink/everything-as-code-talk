resource "docker_image" "mysql" {
  name = "mysql:latest"
}

resource "docker_container" "mysql" {
  name = "wordpress-mysql"
  image = "${docker_image.mysql.latest}"
  env = [
    "MYSQL_ROOT_PASSWORD=secpass"
  ]
}

resource "docker_image" "wordpress" {
  name = "wordpress:latest"
}

resource "docker_container" "wordpress" {
  name = "wordpress"
  image = "${docker_image.wordpress.latest}"
  env = [
    "WORDPRESS_DB_HOST=${docker_container.mysql.ip_address}",
    "WORDPRESS_DB_PASSWORD=secpass"
  ]
  ports {
    internal = "80"
    external = "8085"
  }
}


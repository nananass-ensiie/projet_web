# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Administrateur.create(nom: 'admin', email: 'hanna.benjedidia@gmail.com', password: 'admin')
Teacher.create(surname: 'd', name: 'd', password: 'd', email: 'd@d', role: 'accepte')
Studient.create(surname: 'Nom', name: 'Prenom', password: '1', email: 'eleve@eleve')

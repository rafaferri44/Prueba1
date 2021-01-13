#!/usr/bin/python3
import psycopg2
import os
import shutil
from PIL import Image

try:
	print("Iniciando la conexion...")
	conn = psycopg2.connect(
	host="192.168.3.106",
	database="dhestia",
	user="postgres",
	password="postgres")

	print("Obteniendo los datos...")
	cur = conn.cursor()
	cur.execute("SELECT referencia FROM articulos LIMIT 100")
	data = cur.fetchall()
	contenido = os.listdir(path='/var/www/original/')	

	print("Datos obtenidos correctamente...")
	for i in data:
		for e in contenido:
			if (i[0]+".jpg") == e:
				#print(i,"=", e)
				#f = open("./hola.txt", "a")
				img = Image.open('/var/www/original/'+e)
				widht = img.size[0]
				height = img.size[1]
				base = (250, 750, 1024)
				if widht > height:
					for a in base:
						wpercent = (a/float(height))
						wsize = int((float(widht)*float(wpercent)))
						newImg = img.resize((wsize,a))
						if a == 250:
							newImg.save('/var/www/redimension/min/'+e)
						elif a == 750:
							newImg.save('/var/www/redimension/med/'+e)
						elif a == 1024:
							newImg.save('/var/www/redimension/max/'+e)

				elif height > widht:
					for b in base:
						hpercent = (b/float(widht))
						hsize = int((float(height)*float(hpercent)))
						newImg2 = img.resize((hsize,b))
						if b == 250:
							newImg2.save('/var/www/redimension/min/'+e)
						elif b == 750:
							newImg2.save('/var/www/redimension/med/'+e)
						elif b == 1024:
							newImg2.save('/var/www/redimension/max/'+e)

				#f.write(repr(img)+"\n")
				#f.close()
			#else:
				#print(i,"No es igual a ",e)
	conn.close()
except:
	print("La operacion se ha cancelado")

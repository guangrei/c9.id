from datetime import datetime
from pytz import timezone

def say():
	tz = timezone("Asia/Jakarta")
	now = datetime.now(tz)
	jam = now.hour
	menit = now.minute
	if jam >= 00 and jam < 10:
		if menit > 00 and menit < 60:
			return "Selamat Pagi"
	elif jam >= 10 and jam < 15:
		if menit > 00 and menit < 60:
			return "Selamat Siang"
	elif jam >= 15 and jam < 18:
		if menit > 00 and menit < 60:
			return "Selamat Sore"
	elif jam >= 18 and jam <= 24:
		if menit > 00 and menit < 60:
			return "Selamat Malam"
	else:
		return "Halo" # ahir fungsi
		
print "> %s, jika menemukan masalah silahkan open issue di https://github.com/guangrei/c9.id/issues"%say()
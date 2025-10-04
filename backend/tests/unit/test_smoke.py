def test_import_app():
	import sys
	sys.path.insert(0, 'D:/OneDrive/Desktop/Mood/backend')
	from app import main
	assert hasattr(main, 'app')

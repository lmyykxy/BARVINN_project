import os

def list_files_in_directory(directory):
	for root, _, files in os.walk(directory):
		for file in files:
			absolute_path = os.path.join(root, file)
			print(absolute_path)

if __name__ == "__main__":
	input_directory = "/home/qingteng/Documents/Front_end/mvu_asic/sim/src"
	list_files_in_directory(input_directory)

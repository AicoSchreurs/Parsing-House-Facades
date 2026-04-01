import json
import os

folder_input = "to_convert"
folder_output = "converted"

for file in os.listdir(folder_input):
    if file.endswith(".json"):
        path = os.path.join(folder_input, file)
        path_output = os.path.join(folder_output, file)

        with open(path, "r") as f:
            data = json.load(f)

        # Converteer de data naar een string en vervang alle voorkomens
        data_str = json.dumps(data)
        data_str = data_str.replace('"raam"', '"Raam"')
        data_str = data_str.replace('"window"', '"Raam"')
        data_str = data_str.replace('"Zolderraam"', '"Raam"')
        data_str = data_str.replace('"Garagedeur"', '"Deur"')
        data_str = data_str.replace('"deur"', '"Deur"')
        data_str = data_str.replace('"door"', '"Deur"')
        data_str = data_str.replace('"zonnepaneel"', '"Zonnepaneel"')
        data_str = data_str.replace('"solar"', '"Zonnepaneel"')
        data_str = data_str.replace('"zonnepanelen"', '"Zonnepaneel"')

        # Converteer terug naar JSON
        data = json.loads(data_str)

        # Pas het pad aan
        if "imagePath" in data:
            data["imagePath"] = data["imagePath"].replace("..\\", "")
        
        # Sla het gewijzigde bestand op
        with open(path_output, "w") as f:
            json.dump(data, f, indent=4)

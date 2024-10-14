
from dataclasses import dataclass

import yaml

@dataclass
class Settings():
    project_name: str

def get_settings(config_path:str) -> Settings:
    with open(config_path, "r") as file:
        config = yaml.load(file, Loader=yaml.FullLoader)
    settings = Settings(
        project_name=config.get("project_name")
    )
    return settings

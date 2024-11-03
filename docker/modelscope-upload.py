import os

from modelscope.hub.api import HubApi


if __name__ == '__main__':
    YOUR_ACCESS_TOKEN = os.environ.get('MODELSCOPE_TOKEN')
    api = HubApi()
    api.login(YOUR_ACCESS_TOKEN)

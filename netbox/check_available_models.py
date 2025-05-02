#!/usr/bin/env python

import os
import sys

import django

sys.path.append('/opt/netbox/netbox')
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "netbox.settings")
django.setup()

from django.apps import apps

# essayer avec core ou extras....
models = apps.get_app_config("core").get_models()
for model in models:
    print(model.__name__)

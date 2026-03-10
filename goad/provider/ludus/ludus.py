"""Ludus provider router: detects Ludus version and delegates to the correct implementation."""

import re
from goad.command.cmd_factory import CommandFactory
from goad.log import Log
from goad.utils import *


def _get_ludus_major_version(config):
    """Run `ludus version` and return the major version number (1 or 2). Defaults to 1 on failure or the value of LUDUS_VERSION environment variable."""
    if 'LUDUS_VERSION' in os.environ:
        return int(os.environ['LUDUS_VERSION'])
    # THERE is a regression with that on other providers so fallback to export LUDUS_VERSION=2 for v2
    # api_key = config.get_value('ludus', 'ludus_api_key', 'not_set')
    # command = CommandFactory.get_command()
    # ## Version command does not require a lab path; cwd=None uses current directory
    # output = command.run_ludus_result(['version'], None, api_key, do_log=False)
    # if not output:
    #     return 1
    # # Match first digit sequence (e.g. "1.2.3", "v2.0.0", "Version: 2.0.0")
    # match = re.search(r'(\d+)\.(\d+)\.(\d+)', output)
    # if match:
    #     return int(match.group(1))
    return 1


def get_ludus_provider(lab_name, config):
    """Return the appropriate Ludus provider instance for the installed Ludus version."""
    major = _get_ludus_major_version(config)
    if major == 2:
        from goad.provider.ludus.ludus2 import Ludus2Provider
        return Ludus2Provider(lab_name, config)
    from goad.provider.ludus.ludus1 import Ludus1Provider
    return Ludus1Provider(lab_name, config)

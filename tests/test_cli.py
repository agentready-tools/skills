import contextlib
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

from agentready_cli import __main__ as cli


class CliTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tools = json.loads(Path('catalog/fixtures/tools.json').read_text())['tools']

    def test_search_is_case_insensitive_and_uses_description(self):
        self.assertEqual([x['slug'] for x in cli.run(self.tools, 'search', 'VENDOR-WRITTEN')], ['example-search-mcp'])
        self.assertEqual(cli.run(self.tools, 'search', 'missing'), [])

    def test_get_and_link(self):
        item = cli.run(self.tools, 'get', 'example-weather-api')
        self.assertEqual(item['url'], 'https://agentready-tools.com/tools/example-weather-api?ref=github')
        with self.assertRaisesRegex(ValueError, 'tool not found'):
            cli.run(self.tools, 'get', 'missing')

    def test_categories_and_table(self):
        self.assertEqual(cli.run(self.tools, 'categories'), ['Search', 'Weather'])
        self.assertIn('Example Search MCP', cli.table(cli.run(self.tools, 'search', 'search')))
        self.assertEqual(cli.table([]), 'No results.')

    def test_cli_json_and_error(self):
        with patch.object(cli, 'load_catalog', return_value=self.tools), contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(cli.main(['--json', 'get', 'example-search-mcp']), 0)
            self.assertEqual(json.loads(out.getvalue())['slug'], 'example-search-mcp')
        with patch.object(cli, 'load_catalog', side_effect=OSError('offline')), contextlib.redirect_stderr(io.StringIO()) as err:
            self.assertEqual(cli.main(['categories']), 1)
            self.assertIn('offline', err.getvalue())

    def test_reject_empty_query(self):
        with self.assertRaises(ValueError):
            cli.run(self.tools, 'search', '  ')


if __name__ == '__main__':
    unittest.main()

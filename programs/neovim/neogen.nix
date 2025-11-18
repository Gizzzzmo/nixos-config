{standalone, ...}:
{
  enable = true;
}
// (
  if standalone
  then {snippetEngine = "luasnip";}
  else {
    settings = {
      snippet_engine = "luasnip";
    };
  }
)

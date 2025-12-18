{standalone, ...}: {
  enable = true;

  settings = {
    snippet_engine = "luasnip";
  };
}
# // (
#   if standalone
#   then {snippetEngine = "luasnip";}
#   else {
#     settings = {
#       snippet_engine = "luasnip";
#     };
#   }
# )


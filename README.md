# gm_helzie
The provided repository contains files of a passive backdoor and server files stealer I wrote to attack large servers in Garry's Mod. It was also used to obtain Willard Networks server files. Has distinct advantages over typical backdoors:
* Exploits mutation of addon files by overriding `lua/includes/init.lua`, which ensures that the payload is initialized even before the server. A priori detours shitty defenders such as "eProtect".
* Provides a good remote code execution module that uses concommands rather than netstrings. Makes it invisible to retarded defenders such as "eProtect" and literally any netloggers around.
* Has a robust (better than nothing, lol) C2 server that handles edge cases (e.g., only saves duplicate files if any changes have been made)

**However,**
* **Many** variables are hardcoded in both Lua and PHP. I couldn't be bothered to make any configurations for such a simple and specific project. Therefore, you have to change them manually:
  * `lua/includes/modules/helzie.lua` (line 19): Consider adding or removing domains of interest that are used in the `Skim()` function.
  * `lua/includes/modules/helzie.lua` (line 84): You must set the url of your own self-hosted C2 server without the "/" at the end.
  * `lua/includes/modules/helzie.lua` (line 98): You must set the secret of your own self-hosted C2 server. It's a simple measure to prevent exploitation of your C2 server in case if the URL is exposed.
  * `lua/includes/modules/playground.lua` (line 37): Consider changing the name of your RCE concommand.
  * `lua/includes/modules/playground.lua` (line 38): Consider changing the secret to access the `r_delude` command (which the client must pass as the 2nd argument)
  * `public/forwarder/forward.php` (line 20): You must set the secret of your own self-hosted C2 server.
* It requires the `hook` and `command` libraries beforehand. That's is why I included the `IsValid()` hack in `lua/includes/init.lua`, and that's why you should be prepared for edge cases where this backdoor creates errors in custom hooks because of a certain function or variable is not declared (actually quite rare, except for `IsValid()`).
* The C2 server was built for PHP FastCGI (Apache) 8.3.8. Keep this in mind when hosting it yourself.
 
It's really easy to use if you're not retarded. You can modify it the way you want, but don't forget about localizing global functions to prevent them from being modified by those peaky "server defenders".

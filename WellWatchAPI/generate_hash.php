<?php
// generate_hash.php - gera um hash BCRYPT para a senha "123456"
echo password_hash("123456", PASSWORD_BCRYPT);
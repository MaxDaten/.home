# System settings of user
{ pkgs, config, ... }:
{
  users.extraUsers.jloos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    hashedPassword = "$6$H9kP.kHWqSBn1rE4$huEYYhX0UrpsCCViIwWFHinRJnMVjgSbOoynKF0t79Itlb5ReqAztQDm.Q.t5LXl/70vuVnCx8bXf3nLJHd1S0";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDICvbuJuq1NNPE0bPVA8s2HGh4FBGMW7mbl5iLzyDfCdvuG0LWs56OtqrnRK/d18cik3r7DIFQ2/B7d6kz2uCcUmV8BegQQ1atud532gIRMUI9s/v4zcUnmCtoUDBbWUiEJvbjNU8oJT8VxWmKnD8nSFuCpSttER7IBdB0oICEPTPvTq01pafrhD8L/L+pS4mKFHjARBuNhi7Va7TEbbIuQQgt028fMjgaL9b/dS1lHUn5Uw9yd3/MfLUS7fNhlK+cn6HvJfQL7FgH5WXZBfxiVJo1iPmFTSio6Qo7PyY27Po8zEmNA+7mNHBms4rloOGYDHmoHY1tSuc1cVfMfL/l jloos@macbook"
    ];
  };
}
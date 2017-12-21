#
type Openondemand::Acl = Struct[{ 'adapter' => Enum['group'],
                                  'groups'  => Optional[Array],
                                  'type'    => Enum['whitelist', 'blacklist']
                               }]
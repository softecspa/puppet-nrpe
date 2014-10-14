Facter.add("root_dev") do
    setcode do
        Facter::Util::Resolution.exec('/bin/bash -c /usr/local/bin/root_device')
    end
end

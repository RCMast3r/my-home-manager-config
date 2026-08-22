# nebs-desktop: Fedora, discrete NVIDIA card, CUDA.
{ inputs, system, username }:

{
  stateVersion = "26.05";

  # Drives targets.genericLinux.gpu.nvidia in home.nix. update.sh rewrites
  # ../nvidia-driver-pin.nix from /proc/driver/nvidia/version on every run, so
  # the userspace libs always match the loaded kernel module.
  nvidiaGpu = import ../nvidia-driver-pin.nix;

  nixpkgsConfig = {
    # Needed to build the NVIDIA userspace libs that
    # targets.genericLinux.gpu.nvidia pulls from download.nvidia.com.
    nvidia.acceptLicense = true;
  };

  overlays = [
    (final: prev: {
      llama-cpp = prev.llama-cpp.override { cudaSupport = true; };
    })
  ];

  modules = [ ];
}

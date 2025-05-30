import { format } from "date-fns";

const ClockHook = {
  mounted() {
    // Get the time display element
    const timeElement = this.el.querySelector(`#${this.el.id}-time`);
    
    // Start a client-side interval to update the time every second
    this.interval = setInterval(() => {
      const now = new Date();
      timeElement.textContent = format(now, "hh:mm:ss a");
    }, 1000);
  },
  destroyed() {
    // Clean up the interval when the component is unmounted
    clearInterval(this.interval);
  }
};

export default ClockHook;